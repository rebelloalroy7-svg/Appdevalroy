
module.exports = {
  preset: "jest-expo",
  transformIgnorePatterns: [
    "node_modules/(?!(@react-native|react-native|react-clone-referenced-element)/)"
  ],
};
