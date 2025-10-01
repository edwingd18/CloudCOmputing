function updateInfo() {
    document.getElementById('hostname').textContent = window.location.hostname || 'localhost';
    document.getElementById('timestamp').textContent = new Date().toLocaleString('es-ES');
}

function refreshPage() {
    location.reload();
}

updateInfo();
setInterval(updateInfo, 1000);
