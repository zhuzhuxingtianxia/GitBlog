import React from 'react'
import { Button } from "antd-mobile";
import './index.less'

const statusMode = {
    '404':{
        status:'404',
        content: '抱歉，你访问的页面不存在',
    },
    '403':{
        status:'403',
        content: '抱歉，你无权访问该页面',
    },
    '500':{
        status:'500',
        content: '抱歉，服务器出错了',
    },
}

class ErrorCompontent extends React.Component {
    static defaultProps = {
        status:'',
        content: '',
        mode:'404'
    }

    componentDidMount(){

    }

    linkMethod = ()=> {
        if(window.appClose) {
            window.appClose()
        }else {
            window.history.push('/')
        }
    }

    render() {
        const modeObj = statusMode[this.props.mode] || {}
        return (
            <div className='pageError'>
                <h1 className='title'>{ this.props.status || modeObj.status }</h1>
                <div className='info'>{ this.props.content || modeObj.content }</div>
                <Button className='btn' type='primary' size='small'
                    onClick={this.linkMethod}
                >返回</Button>
            </div>
        )
    }
}

export default ErrorCompontent;