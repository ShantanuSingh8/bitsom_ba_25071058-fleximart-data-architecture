use fleximart_catalog;

// Operation 1: Load Data
db.products.insertMany([
  {
    "product_id": "ELEC001",
    "name": "Samsung Galaxy S21",
    "category": "Electronics",
    "price": 799.99,
    "stock": 150,
    "specs": {
      "ram": "8GB",
      "storage": "128GB"
    },
    "reviews": [
      {"user": "U001", "rating": 5, "comment": "Great!", "date": ISODate("2024-01-15")}
    ]
  },
  {
    "product_id": "ELEC002",
    "name": "MacBook Pro 14",
    "category": "Electronics",
    "price": 1999.99,
    "stock": 45,
    "specs": {
      "ram": "16GB",
      "storage": "512GB SSD",
      "processor": "Apple M2"
    },
    "reviews": [
      {"user": "U003", "rating": 5, "comment": "Excellent performance", "date": ISODate("2024-02-01")}
    ]
  },
  {
    "product_id": "SHOE001",
    "name": "Nike Air Max 270",
    "category": "Footwear",
    "price": 150.00,
    "stock": 300,
    "specs": {
      "size": "10",
      "color": "Black/White"
    },
    "reviews": [
      {"user": "U010", "rating": 4, "comment": "Comfortable", "date": ISODate("2024-01-18")}
    ]
  }
]);

print("Operation 1: Data loaded");

// Operation 2: Basic Query
// Electronics products with price < 50000

db.products.find(
  {
    category: "Electronics",
    price: { $lt: 50000 }
  },
  {
    _id: 0,
    name: 1,
    price: 1,
    stock: 1
  }
);

print("Operation 2: Basic query done");

// Operation 3: Review Analysis
// Products with average rating >= 4.0

db.products.aggregate([
  {
    $project: {
      name: 1,
      category: 1,
      price: 1,
      avg_rating: {
        $avg: "$reviews.rating"
      },
      review_count: {
        $size: {
          $ifNull: ["$reviews", []]
        }
      }
    }
  },
  {
    $match: {
      avg_rating: { $gte: 4.0 }
    }
  },
  {
    $sort: {
      avg_rating: -1
    }
  }
]);

print("Operation 3: Review analysis done");

// Operation 4: Update Operation
// Add review to product ELEC001

db.products.updateOne(
  {
    product_id: "ELEC001"
  },
  {
    $push: {
      reviews: {
        user: "U999",
        rating: 4,
        comment: "Good value",
        date: new Date()
      }
    }
  }
);

print("Operation 4: Review added");

// Operation 5: Complex Aggregation
// Average price by category

db.products.aggregate([
  {
    $group: {
      _id: "$category",
      avg_price: {
        $avg: "$price"
      },
      product_count: {
        $sum: 1
      }
    }
  },
  {
    $project: {
      _id: 0,
      category: "$_id",
      avg_price: {
        $round: ["$avg_price", 2]
      },
      product_count: 1
    }
  },
  {
    $sort: {
      avg_price: -1
    }
  }
]);

print("Operation 5: Aggregation done");

print("\nAll operations completed!");

