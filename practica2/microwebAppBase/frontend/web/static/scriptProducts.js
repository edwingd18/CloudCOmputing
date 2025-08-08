function getProducts() {
  fetch("http://192.168.50.4:5003/api/products")
    .then((response) => response.json())
    .then((data) => {
      // Handle data
      console.log(data);

      // Get table body
      var productListBody = document.querySelector("#product-list tbody");
      productListBody.innerHTML = ""; // Clear previous data

      // Loop through products and populate table rows
      data.forEach((product) => {
        var row = document.createElement("tr");

        // Name
        var nameCell = document.createElement("td");
        nameCell.textContent = product.name;
        row.appendChild(nameCell);

        // Price
        var priceCell = document.createElement("td");
        priceCell.textContent = "$" + parseFloat(product.price).toFixed(2);
        row.appendChild(priceCell);

        // Stock
        var stockCell = document.createElement("td");
        stockCell.textContent = product.stock;
        row.appendChild(stockCell);

        // Description
        var descriptionCell = document.createElement("td");
        descriptionCell.textContent = product.description;
        row.appendChild(descriptionCell);

        // Actions
        var actionsCell = document.createElement("td");

        // Edit link
        var editLink = document.createElement("a");
        editLink.href = `/editProduct/${product.id}`;
        editLink.textContent = "Edit";
        editLink.className = "btn btn-primary mr-2";
        actionsCell.appendChild(editLink);

        // Delete link
        var deleteLink = document.createElement("a");
        deleteLink.href = "#";
        deleteLink.textContent = "Delete";
        deleteLink.className = "btn btn-danger";
        deleteLink.addEventListener("click", function () {
          deleteProduct(product.id);
        });
        actionsCell.appendChild(deleteLink);

        row.appendChild(actionsCell);

        productListBody.appendChild(row);
      });
    })
    .catch((error) => console.error("Error:", error));
}

function createProduct() {
  var data = {
    name: document.getElementById("name").value,
    price: parseFloat(document.getElementById("price").value),
    stock: parseInt(document.getElementById("stock").value),
    description: document.getElementById("description").value,
  };

  fetch("http://192.168.50.4:5003/api/products", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then((data) => {
      // Handle success
      console.log(data);
      // Clear form
      document.getElementById("add-product-form").reset();
      // Refresh product list
      getProducts();
    })
    .catch((error) => {
      // Handle error
      console.error("Error:", error);
    });
}

function updateProduct() {
  var productId = document.getElementById("product-id").value;
  var data = {
    name: document.getElementById("name").value,
    price: parseFloat(document.getElementById("price").value),
    stock: parseInt(document.getElementById("stock").value),
    description: document.getElementById("description").value,
  };

  fetch(`http://192.168.50.4:5003/api/products/${productId}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  })
    .then((response) => {
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    })
    .then((data) => {
      // Handle success
      console.log(data);
      // Redirect to products page
      window.location.href = "/products";
    })
    .catch((error) => {
      // Handle error
      console.error("Error:", error);
    });
}

function deleteProduct(productId) {
  console.log("Deleting product with ID:", productId);
  if (confirm("Are you sure you want to delete this product?")) {
    fetch(`http://192.168.50.4:5003/api/products/${productId}`, {
      method: "DELETE",
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Network response was not ok");
        }
        return response.json();
      })
      .then((data) => {
        // Handle success
        console.log("Product deleted successfully:", data);
        // Reload the product list
        getProducts();
      })
      .catch((error) => {
        // Handle error
        console.error("Error:", error);
      });
  }
}