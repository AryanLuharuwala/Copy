const express = require("express");
const cors = require("cors");

const app = express();

// Use CORS middleware to allow all origins
app.use(cors());

app.get("/api/products", (req, res) => {
  console.log("Request received for /api/products");
  res.status(200).json({
    "page": 1,
    "products": [
      {
        "productId": "1",
        "sellerId": "101",
        "name": "Synthetic Product A",
        "price": 120,
        "images": [
          {
            "url": "https://images.unsplash.com/photo-1731351621470-8aebda14d242?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.0.3",
            "altText": "Front view of Synthetic Product A"
          },
          {
            "url": "https://images.unsplash.com/photo-1731351621470-8aebda14d242?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.0.3",
            "altText": "Side view of Synthetic Product A"
          }
        ],
        "description": "This is a synthetic description for Product A."
      },
      {
        "productId": "2",
        "sellerId": "102",
        "name": "Synthetic Product B",
        "price": 180,
        "images": [
          {
            "url": "https://images.unsplash.com/photo-1731351621470-8aebda14d242?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.0.3",
            "altText": "Front view of Synthetic Product B"
          }
        ],
        "description": "This is a synthetic description for Product B."
      },
      {
        "productId": "3",
        "sellerId": "103",
        "name": "Synthetic Product C",
        "price": 220,
        "images": [
          {
            "url": "https://via.placeholder.com/800x600.png?text=Front+view+of+Product+C",
            "altText": "Front view of Synthetic Product C"
          },
          {
            "url": "https://via.placeholder.com/800x600.png?text=Side+view+of+Product+C",
            "altText": "Side view of Synthetic Product C"
          }
        ],
        "description": "This is a synthetic description for Product C."
      },
      {
        "productId": "4",
        "sellerId": "104",
        "name": "Synthetic Product D",
        "price": 260,
        "images": [
          {
            "url": "https://via.placeholder.com/800x600.png?text=Front+view+of+Product+D",
            "altText": "Front view of Synthetic Product D"
          }
        ],
        "description": "This is a synthetic description for Product D."
      },
      {
        "productId": "5",
        "sellerId": "105",
        "name": "Synthetic Product E",
        "price": 320,
        "images": [
          {
            "url": "https://via.placeholder.com/800x600.png?text=Front+view+of+Product+E",
            "altText": "Front view of Synthetic Product E"
          },
          {
            "url": "https://via.placeholder.com/800x600.png?text=Side+view+of+Product+E",
            "altText": "Side view of Synthetic Product E"
          }
        ],
        "description": "This is a synthetic description for Product E."
      }
    ]
  }
  
  );
});

app.listen(3000, () => {
  console.log("Server running on http://localhost:3000");
});
