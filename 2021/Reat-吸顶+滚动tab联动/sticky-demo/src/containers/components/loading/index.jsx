import React from 'react'
import { ActivityIndicator } from "antd-mobile";

export default class LoadingPage extends React.Component {
    static defaultProps = {
        loading: true
    }

    render() {
        return (
            <div>
                <ActivityIndicator
                    toast
                    text={'加载中...'}
                    animating={this.props.loading}
                />
            </div>
        )
    }

}