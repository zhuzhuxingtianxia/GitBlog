import React from 'react';
import { Header } from "@com";
import './index.less';

const Detail = (props={}) => {

    return (
        <div className='detail_page'>
            <Header>{'详情'}</Header>
            <div className='wrap_content'>
                <div onClick={()=>{
                    window.appHistory.goBack()
                 }}>goBack</div>
            </div>
            
        </div>
    )
}

export default Detail;