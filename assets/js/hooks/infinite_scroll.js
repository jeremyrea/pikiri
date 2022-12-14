export const InfiniteScroll = {
    cursor() {
      return this.el.dataset.cursor;
    },
    loadMore(entries) {
      const target = entries[0];
      if (target.isIntersecting && this.pending == this.cursor()) {
        this.pending = this.cursor();
        this.pushEvent("load-more", {cursor: this.cursor()});
      }
    },
    mounted() {
      this.pending = this.cursor();
      this.observer = new IntersectionObserver(
        (entries) => this.loadMore(entries),
        {
          root: null, // window by default
          rootMargin: "0px",
          threshold: 1.0,
        }
      );
      this.observer.observe(this.el);
    },
    beforeDestroy() {
      this.observer.unobserve(this.el);
    },
    updated() {
      this.pending = this.cursor();
    },
  };