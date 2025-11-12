// src/api/ApiService.js
import axios from "axios";

// Create Axios instance
const API = axios.create({
  baseURL: "https://jsonplaceholder.typicode.com",
  timeout: 10000,
});

// REST API functions
export const getPosts = () => API.get("/posts");
export const getComments = () => API.get("/comments");
export const createPost = (payload) => API.post("/posts", payload);
export const updatePost = (id, payload) => API.put(`/posts/${id}`, payload);
export const deletePost = (id) => API.delete(`/posts/${id}`);
