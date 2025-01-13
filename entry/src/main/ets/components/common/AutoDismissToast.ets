@Component
export struct AutoDismissToast {
  @Require @Prop @Watch("_onPropertyDidChange") message: string
  @State private showMessage: string = ''
  private _timeoutId: number = 0;

  aboutToDisappear(): void {
    if (this._timeoutId) {
      clearTimeout(this._timeoutId);
    }
  }

  resetTimeout() {
    if (this._timeoutId) {
      clearTimeout(this._timeoutId);
    }
    this._timeoutId = setTimeout(() => {
      this.showMessage = '';
      this._timeoutId = 0;
    }, 1300);
  }

  build() {
    Text(this.showMessage)
      .fontSize(24)
      .fontWeight(FontWeight.Medium)
      .fontColor(Color.White)
  }

  _onPropertyDidChange(propertyName: string) {
    if (propertyName === 'message') {
      if (this.showMessage !== this.message) {
        this.showMessage = this.message
        this.resetTimeout()
      }
    }
  }
}