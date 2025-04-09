from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel, cosine_similarity
from sklearn.preprocessing import normalize
from pymongo import MongoClient
from bson.objectid import ObjectId
from bson.errors import InvalidId
from collections import defaultdict

app = Flask(__name__)
CORS(app)

# ✅ Connect to MongoDB Atlas
client = MongoClient("mongodb+srv://leonlangat:Shineguy%402001@cluster0.dmesj.mongodb.net/test?retryWrites=true&w=majority&appName=Cluster0")
db = client["test"]
users_collection = db["users"]

# ✅ Load and preprocess dataset
df = pd.read_csv("stratified_sample.csv")
df.dropna(subset=['title', 'abstract', 'categories', 'id'], inplace=True)

# ✅ Filter to keep only valid arXiv IDs
arxiv_id_pattern = re.compile(r'^\d{4}\.\d{4,5}(v\d+)?$|^[a-z\-]+(.[A-Z]{2})?/\d{7}$')
df = df[df['id'].apply(lambda x: bool(arxiv_id_pattern.match(str(x))))]

# Clean text fields
df['title'] = df['title'].str.lower().apply(lambda x: re.sub(r'[^a-z0-9\s]', '', x))
df['abstract'] = df['abstract'].str.lower().apply(lambda x: re.sub(r'[^a-z0-9\s]', '', x))
df['id'] = df['id'].astype(str)

# ✅ Use /abs/ to avoid broken PDF links
df['link'] = 'https://arxiv.org/pdf/' + df['id']

# ✅ Limit dataset size
df_sample = df.iloc[:10000].copy()
tfidf = TfidfVectorizer(stop_words="english")
tfidf_matrix = tfidf.fit_transform(df_sample['abstract'])
cosine_sim = linear_kernel(tfidf_matrix, tfidf_matrix)
indices = pd.Series(df_sample.index, index=df_sample['title']).drop_duplicates()

# ✅ Precompute mean and std similarity for hybrid scoring
article_means = cosine_sim.mean(axis=1)
article_stds = cosine_sim.std(axis=1)

# ✅ Group categories
category_map = defaultdict(set)
for cat_string in df['categories'].dropna():
    for cat in cat_string.split():
        if '.' in cat:
            main, _ = cat.split('.', 1)
            category_map[main].add(cat)
        else:
            category_map[cat].add(cat)

grouped_categories = {main: sorted(list(subs)) for main, subs in category_map.items()}


@app.route('/recommend/title', methods=['POST'])
def recommend_by_title():
    title = request.json.get("title", "").lower()
    if title not in indices:
        return jsonify({"error": "Title not found"}), 404

    idx = indices[title]
    sim_scores = list(enumerate(cosine_sim[idx]))
    sim_scores = sorted(sim_scores, key=lambda x: x[1], reverse=True)[1:15]

    results = []
    for i, score in sim_scores:
        paper = df_sample.iloc[i]
        results.append({
            "title": paper['title'],
            "categories": paper['categories'],
            "link": paper['link'],
            "similarity_score": round(score, 4)
        })

    return jsonify(results)


@app.route('/recommend/categories', methods=['POST'])
def recommend_by_category():
    user_topics = request.json.get("topics", [])
    print("🧠 Topics received:", user_topics)

    if not user_topics:
        return jsonify({"error": "No topics provided"}), 400

    topic_to_indices = {}
    N_per_topic = 30

    # Collect indices of relevant articles for each topic
    for topic in user_topics:
        matches = df_sample[df_sample['categories'].str.contains(re.escape(topic), na=False)].index.tolist()
        topic_to_indices[topic] = matches[:N_per_topic]

    all_indices = list(set(i for indices in topic_to_indices.values() for i in indices))
    if not all_indices:
        return jsonify([])

    # Prepare topic vectors to build user profile
    topic_vectors = []
    for indices_list in topic_to_indices.values():
        if indices_list:
            vectors = tfidf_matrix[indices_list]
            normalized = normalize(vectors, axis=1)
            topic_vectors.append(normalized.toarray())

    if not topic_vectors:
        return jsonify([])

    # Build user profile vector (average of topic vectors)
    user_profile_vector = np.vstack(topic_vectors).mean(axis=0).reshape(1, -1)

    # Filter articles and compute similarity with user profile
    filtered_articles = df_sample.loc[all_indices].copy()
    filtered_tfidf = tfidf_matrix[all_indices]
    user_sim_scores = linear_kernel(user_profile_vector, filtered_tfidf).flatten()

    # Apply precomputed mean and std similarity
    filtered_articles['similarity_score'] = user_sim_scores
    filtered_articles['mean_similarity'] = filtered_articles.index.map(lambda i: article_means[i])
    filtered_articles['std_similarity'] = filtered_articles.index.map(lambda i: article_stds[i])
    filtered_articles['hybrid_score'] = filtered_articles['mean_similarity'] - filtered_articles['std_similarity']

    # Optional: filter overly generic articles
    filtered_articles = filtered_articles[filtered_articles['std_similarity'] >= 0.018]

    # Sort by hybrid_score and return top 15
    filtered_articles = filtered_articles.sort_values(by='hybrid_score', ascending=False).head(15)
    filtered_articles['similarity_score'] = filtered_articles['similarity_score'].round(4)
    filtered_articles['hybrid_score'] = filtered_articles['hybrid_score'].round(4)

    # Final fields
    recommendations = filtered_articles[[
        'title', 'categories', 'link',
        'similarity_score', 'mean_similarity', 'std_similarity', 'hybrid_score'
    ]]

    return jsonify(recommendations.to_dict(orient="records"))


@app.route('/categories', methods=['GET'])
def get_categories():
    all_categories = df['categories'].dropna().str.split().explode().unique().tolist()
    return jsonify(all_categories)


@app.route('/grouped-categories', methods=['GET'])
def get_grouped_categories():
    return jsonify(grouped_categories)


@app.route('/api/auth/set-interests', methods=['PUT'])
def set_interests():
    try:
        data = request.get_json()
        print("📩 Received interests data from frontend:")
        print(data)

        user_id = data.get('userId')
        if not user_id:
            return jsonify({"error": "User ID is required"}), 400

        result = users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {
                "$set": {
                    "interests": {
                        "categories": data.get("categories", []),
                        "subcategories": data.get("subcategories", {})
                    },
                    "interestsSet": True,
                    "firstLogin": False
                }
            }
        )

        if result.matched_count == 0:
            return jsonify({"error": "User not found"}), 404

        return jsonify({"message": "Interests saved successfully"}), 200

    except Exception as e:
        print(f"❌ Error updating interests in MongoDB: {e}")
        return jsonify({"error": "Server error"}), 500


@app.route('/api/auth/get-interests/<user_id>', methods=['GET'])
def get_interests(user_id):
    print(f"📤 Fetching interests for user {user_id}")
    try:
        try:
            user_object_id = ObjectId(user_id)
        except InvalidId:
            return jsonify({"error": "Invalid user ID format"}), 400

        user = users_collection.find_one(
            {"_id": user_object_id},
            {"interests": 1, "interestsSet": 1}
        )

        if not user:
            return jsonify({"error": "User not found"}), 404

        return jsonify({
            "interests": user.get("interests", {}),
            "interestsSet": user.get("interestsSet", False)
        }), 200

    except Exception as e:
        print(f"❌ Error fetching user interests from MongoDB: {e}")
        return jsonify({"error": "Server error"}), 500


@app.route('/api/auth/reset-interests', methods=['POST'])
def reset_interests():
    try:
        data = request.get_json()
        user_id = data.get('userId')

        if not user_id:
            return jsonify({"error": "User ID is required"}), 400

        result = users_collection.update_one(
            {"_id": ObjectId(user_id)},
            {
                "$set": {
                    "interests": {
                        "categories": [],
                        "subcategories": []
                    },
                    "interestsSet": False
                }
            }
        )

        if result.matched_count == 0:
            return jsonify({"error": "User not found"}), 404

        return jsonify({"message": "Interests reset successfully"}), 200

    except Exception as e:
        print(f"❌ Error resetting interests: {e}")
        return jsonify({"error": "Server error"}), 500


# 🚀 Start server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
