import consumer from "./consumer"

consumer.subscriptions.create("NotifcationChannel", {
  connected() {
    console.log("Connected to NotifcationChannel!");
  },

  disconnected() {
    console.log("Disconnected from NotifcationChannel!");
  },

  received(data) {
    const notificationElement = document.getElementById('notifications-alert');
    let className = data.success ? "success" : "danger"
    notificationElement.classList.add(`text-${className}`)
    notificationElement.innerText = `${data.message}`;
  }
});