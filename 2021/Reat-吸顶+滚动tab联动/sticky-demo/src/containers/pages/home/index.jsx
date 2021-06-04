import React from 'react';
import { Header } from "@com";
import './index.less';

const Home = (props={}) => {

    return (
        <div className='homepage'>
            <Header>{'首页'}</Header>
            <div className='wrap_content'>
                <div onClick={()=>{
                    
                    window.appHistory.push('/detail')
                 }}>goDetail</div>
            </div>
            
        </div>
    )
}

export default Home;