export const ModalControl = {
  mounted() {
    this.el.addEventListener("click", (event) => {
      const target = event.currentTarget
      const action = target.getAttribute("data-action")
      const modalId = target.getAttribute("data-modal-id")
      this.pushEvent(`${action}-${modalId}-modal`, {})
    }, false);
  }
};