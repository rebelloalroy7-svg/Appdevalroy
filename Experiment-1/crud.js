// CRUD Operations on an Array in JavaScript

// Initial array
let fruits = ["Apple", "Banana", "Mango"];

console.log("Initial Array:", fruits);

// CREATE (Add item)
fruits.push("Orange");
console.log("After Create (Add Orange):", fruits);

// READ (Display all items)
console.log("Read (All Fruits):");
fruits.forEach((fruit, index) => {
  console.log(index + " -> " + fruit);
});

// UPDATE (Change item at index 1 -> Banana to Grapes)
fruits[1] = "Grapes";
console.log("After Update (Banana → Grapes):", fruits);

// DELETE (Remove Mango by index)
let removed = fruits.splice(2, 1);
console.log("After Delete (Removed Mango):", fruits);
console.log("Deleted Item:", removed);
