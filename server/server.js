const express = require("express");
const http = require("http");
const admin = require("firebase-admin");

const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL:
    "https://console.firebase.google.com/u/0/project/recyclo-d4295/firestore/data/~2F",
});

const app = express();
const port = process.env.PORT || 3000;
const server = http.createServer(app).listen(port, "192.168.10.71");
const io = require("socket.io")(server);
server.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});

const buyers = []; // Store connected buyers
const sellers = [];

// Function to calculate distance between two points (Haversine formula)
function getDistance(location1, location2) {
  const lat1 = location1.latitude;
  const lon1 = location1.longitude;
  const lat2 = location2.latitude;
  const lon2 = location2.longitude;

  const toRadians = (degree) => degree * (Math.PI / 180);
  const haversine = (theta) => Math.pow(Math.sin(theta / 2), 2);

  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    haversine(dLat) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * haversine(dLon);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

  const earthRadius = 6371.0; // Earth radius in kilometers
  return earthRadius * c;
}

io.on("connection", (socket) => {
  console.log(`user is connected on : ${socket.id}`);

  let userType = null;

  socket.on("seller_login", (sellerInfo) => {
    userType = "Seller";
    sellers.push({
      socketId: socket.id,
      sellerName: sellerInfo.fullname,
      sellerEmail: sellerInfo.email,
      // Add any other relevant seller information
    });
    console.log(`Seller logged in: ${socket.id}`);
  });


  socket.on("buyer_login", (buyerInfo) => {
    userType = "Buyer";
    const buyerSocketId = socket.id;
    buyers.push({
      socketId: buyerSocketId,
      buyerName: buyerInfo.fullname,
      buyerLocation: buyerInfo.location,
      wasteType: buyerInfo.WasteType,
      wasteQuantity: buyerInfo.WasteQuantity,
    });
    console.log(`Buyer login: ${buyerSocketId}`);
  });

  socket.on('buyer_logout', (socketId) => {
    // Remove the buyer from the buyers array based on the socket ID
    const buyerIndex = buyers.findIndex((buyer) => buyer.socketId === socketId);
    if (buyerIndex !== -1) {
      buyers.splice(buyerIndex, 1);
      console.log(`Buyer removed: ${socketId}`);
    }
  });

  socket.on('seller_logout', (socketId) => {
    // Remove the seller from the sellers array based on the socket ID
    const sellerIndex = sellers.findIndex((seller) => seller.socketId === socketId);
    if (sellerIndex !== -1) {
      sellers.splice(sellerIndex, 1);
      console.log(`Seller removed: ${socketId}`);
    }
  });

  socket.on("disconnect", () => {
    if (userType) {
      console.log(`${userType} disconnected: ${socket.id}`);
    }
  });

  socket.on("pickup_request", async (data) => {
    // Handle pickup request here
    console.log("Pickup request received:", data);

    try {
      // Extract seller's waste type and quantity from the emitted data
      const sellerWasteType = data.WasteType;
      const sellerWasteQuantity = data.WasteQuantity;
      const sellerLocation = data.location;

      // Log seller's information
      console.log("Seller Information:");
      console.log(`Waste Type: ${sellerWasteType}`);
      console.log(`Waste Quantity: ${sellerWasteQuantity}`);
      console.log(
        `Location: ${sellerLocation.latitude}, ${sellerLocation.longitude}`
      );

      // Fetch all buyers from Firestore
      const buyersSnapshot = await admin.firestore().collection("buyers").get();

      const allBuyers = buyersSnapshot.docs.map((doc) => doc.data());

      // Log all buyers' information along with distance from the seller's location
      console.log("All Buyers Information:");
      allBuyers.forEach((buyer) => {
        console.log(
          `${buyer.fullname}, Distance: ${getDistance(
            sellerLocation,
            buyer.location
          ).toFixed(2)} km`
        );
      });

      // Filter buyers based on matching waste type and quantity
      const relevantBuyers = allBuyers.filter((buyer) => {
        // Convert strings to boolean values for WasteType
        const pickupRequestWasteType = data.WasteType.map(
          (value) => value === "true"
        );
        // Check if WasteType and WasteQuantity match
        const isMatchingWasteType = buyer.WasteType.every(
          (type, index) => type === pickupRequestWasteType[index]
        );
        return (
          isMatchingWasteType && buyer.WasteQuantity === sellerWasteQuantity
        );
      });

      // Log relevant buyers' information along with distance from the seller's location
      console.log("Relevant Buyers Information:");
      console.log("Filtered Buyers:", relevantBuyers); // Add this line to check the filtered buyers
      relevantBuyers.forEach((buyer) => {
        console.log(`${buyer.fullname}`);
      });

      // Sort relevant buyers based on distance from seller's location
      const sortedRelevantBuyers = relevantBuyers
        .map((buyer) => {
          const distance = getDistance(sellerLocation, buyer.location);
          return { ...buyer, distance };
        })
        .sort((a, b) => a.distance - b.distance);

      // Select the closest relevant buyer
      const selectedBuyer = sortedRelevantBuyers[0];

      if (selectedBuyer) {
        console.log("Selected Buyer:", selectedBuyer);
  
        // Ensure that the selectedBuyer object has a socketId property
      
  
          // Emit an event to the selected buyer with the seller's request information
          io.emit("seller_request", {
            buyerEmail: selectedBuyer.email,
            sellerInfo: {
              sellerName: data.Name,
              sellerEmail: data.Email,
              sellerPhoneNumber: data.PhoneNumber,
              sellerWasteType: data.WasteType,
              sellerWasteQuantity: data.WasteQuantity,
              sellerPlaceName: data.PlaceName,
              sellerLocation: data.location,
            },
          });
          console.log("Emitted seller request to:", selectedBuyer.email);
        
      } else {
        console.log("No relevant buyer found");
      }
    } catch (error) {
      console.error("Error handling pickup request:", error);
    }
  });

  socket.on("accept_request", (data) => {
    // Handle the rejected request logic
    console.log("Seller request accepted by the client", data);

    io.emit('buyer_information',{
      buyerInfo: {
        buyerName: data.buyerInfo.buyerFullName,
        buyerPhoneNumber: data.buyerInfo.buyerPhoneNumber,
        buyerPlaceName: data.buyerInfo.buyerplaceName,
      },
    });
    // Add your specific logic here
  });

  socket.on("reject_request", (data) => {
    // Handle the rejected request logic
    console.log("Seller request rejected by the client", data);
    // Add your specific logic here
  });

  socket.on("cancel_process", (data)=>{
    console.log( "Cancelled by Seller" , data);
  })
});