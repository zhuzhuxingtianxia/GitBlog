import { Toast } from "antd-mobile";

class LoadingState {
    // 设置loading文字
    loadText = '加载中...'

    animating = [];
    addAnimating = (data=true) => {
        if(data) {
            this.animating.push(data)
        }

        if(this.animating.length == 1){
            Toast.loading(this.loadText, 45, () => {
                console.log('Load complete!')
            })
        }
    }

    reduceAnimating = ()=> {
        this.animating.shift()
        if(this.animating.length <= 0){
            Toast.hide()
            this.loadText = '加载中...'
        }
    }

}

export default new LoadingState();