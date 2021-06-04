import React from 'react'
import { NavBar, Icon } from "antd-mobile";

import './index.less'

class Header extends React.Component {

    iconOffset = () => {
        const w = document.documentElement.clientWidth;
        let style = { marginLeft: 15 }
        if(w < 375) {
            style = { marginLeft: 5 }
        }

        return style;
    }

    render() {
        return (
            <div className='headerComponent'>
                <NavBar
                    mode={'light'}
                    icon={
                        <div style={{whiteSpace:'nowrap'}}>
                            <Icon style={{marginLeft:0}}
                                type={'left'}
                                size={'lg'}
                                color={'rgba(0,0,0,0.65)'}
                                onClick={this.props.onLeftClick || window.history.goBack}
                            />
                            <Icon type={'cross'}
                                size={'lg'}
                                color={'rgba(0,0,0,0.65)'}
                                style={ this.iconOffset() }
                                onClick={()=> {
                                    if(this.props.appClose) {
                                        this.props.appClose()
                                    }else {
                                        window.appClose && window.appClose()
                                    }
                                }}
                            />
                        </div>
                    }
                    rightContent={this.props.rightContent || []}
                    className={'headerComponent__navBar'}
                    style={{fontWeight:'bold'}}
                >
                    { this.props.title || this.props.children }
                </NavBar>
            </div>
        )
    }

}

export default Header;