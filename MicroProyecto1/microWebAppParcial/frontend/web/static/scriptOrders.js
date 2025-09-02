function getOrders() {
    fetch('http://192.168.80.3:5004/api/orders', {
     method: 'GET',
     headers: {
        'Content-Type': 'application/json'
        },
     credentials: 'include'
    })
        .then(response => response.json())
        .then(data => {
            console.log(data);

            var ordersListBody = document.querySelector('#orders-list tbody');
            ordersListBody.innerHTML = ''; // Clear previous data

            data.forEach(order => {
                var row = document.createElement('tr');

                var idCell = document.createElement('td');
                idCell.textContent = order.id;
                row.appendChild(idCell);

                var userNameCell = document.createElement('td');
                userNameCell.textContent = order.user_name;
                row.appendChild(userNameCell);

                var userEmailCell = document.createElement('td');
                userEmailCell.textContent = order.user_email;
                row.appendChild(userEmailCell);

                var totalCell = document.createElement('td');
                totalCell.textContent = order.sale_total.toFixed(2);
                row.appendChild(totalCell);

                var dateCell = document.createElement('td');
                dateCell.textContent = new Date(order.date).toLocaleString();
                row.appendChild(dateCell);

                var itemsCell = document.createElement('td');
                var itemsList = document.createElement('ul');
                order.items.forEach(item => {
                    var listItem = document.createElement('li');
                    listItem.textContent = `Product ID: ${item.product_id}, Quantity: ${item.quantity}, Price: ${item.price.toFixed(2)}`;
                    itemsList.appendChild(listItem);
                });
                itemsCell.appendChild(itemsList);
                row.appendChild(itemsCell);

                ordersListBody.appendChild(row);
            });
        })
        .catch(error => console.error('Error fetching orders:', error));
}
