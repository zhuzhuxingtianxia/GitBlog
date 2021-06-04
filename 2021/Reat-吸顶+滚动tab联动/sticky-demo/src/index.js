import React from 'react';
import ReactDOM from 'react-dom';
import { Switch, Router, Route } from "react-router-dom";
import { createBrowserHistory } from "history";
import './index.css';
// import APP from './App'
import  Root from '@pages/root';
import reportWebVitals from './reportWebVitals';

const history = createBrowserHistory()
window.appHistory = history


const PrivateRoute = ({compontent:Component, ...rest}) => {
	// debugger
	return (
		<Route 
		  {...rest}
		  render={props => <Component {...props} />}
		/>
	  )
}

ReactDOM.render(
  <Router history={history}>
    <Switch>
		<PrivateRoute path='/' compontent={Root}/>
    </Switch>
  </Router>,
  document.getElementById('root')
);

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
