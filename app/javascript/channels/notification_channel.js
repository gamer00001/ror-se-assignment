import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    console.log("Connected to NotificationChannel!");
  },

  disconnected() {
    console.log("Disconnected from NotificationChannel!");
  },

  received(data) {
    const notificationElement = document.getElementById('notifications-alert');
    let className = data.success ? "success" : "danger"
    notificationElement.classList.add(`text-${className}`)
    notificationElement.innerText = `${data.message}`;
  }
});