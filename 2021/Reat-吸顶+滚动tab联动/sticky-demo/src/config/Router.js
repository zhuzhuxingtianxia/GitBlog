import React from 'react';
import { Route, Switch} from 'react-router-dom';
import loadable from "@loadable/component";

import NoMatch from "@com/error/index";
import Loading from '@com/loading/index';

const Home = loadable(() => import('@pages/home/index'),{
    fallback:<Loading />
});
const Detail = loadable(() => import('@pages/detail/index'),{
    fallback:<Loading />
});



const Router = (props) => {
    // debugger
    return (
        <Switch>
            <Route exact strict path="/" component={Home}/>
            <Route exact path="/detail" component={Detail}/>

            <Route component={NoMatch}/>
        </Switch>
    )
};

export default Router;