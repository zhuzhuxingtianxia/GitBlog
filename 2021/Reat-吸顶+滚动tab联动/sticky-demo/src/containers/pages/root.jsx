import React,{ Fragment } from 'react';
import Router from "@config/Router";

class RootCompent extends React.Component {

    render(){
        return (
            <Fragment>
                <Router {...this.props}/>
            </Fragment>
        )
    }
}

export default RootCompent;