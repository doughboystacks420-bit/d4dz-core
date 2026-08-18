// html/js/app.js
window.addEventListener('message', function(event) {
    const item = event.data;

    // Direct routing for framework notifications
    if (item.action === 'notify') {
        createNotification(item.text, item.type, item.length);
    }
});

function createNotification(text, type, duration) {
    const container = document.getElementById('notification-container');
    const alertType = type || 'primary';
    const displayLength = duration || 5000;

    const notifyElement = document.createElement('div');
    notifyElement.className = `d4dz-notify ${alertType}`;
    notifyElement.innerText = text;

    container.appendChild(notifyElement);

    setTimeout(() => {
        notifyElement.classList.add('slide-out');
        notifyElement.addEventListener('animationend', () => {
            notifyElement.remove();
        });
    }, displayLength);
}
