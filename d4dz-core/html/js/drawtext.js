// html/js/drawtext.js
window.addEventListener('message', function(event) {
    const item = event.data;

    // Listen for permanent draw text updates
    if (item.action === 'drawtext') {
        const textElement = document.getElementById('d4dz-screen-text');
        
        if (item.text) {
            textElement.innerHTML = `<div class="hud-element">${item.text}</div>`;
            textElement.style.display = 'block';
        } else {
            textElement.style.display = 'none';
            textElement.innerHTML = '';
        }
    }
});
