import './app.scss';
import { Elm } from './Main.elm';

Elm.Main.init({
    node: document.getElementById('elm'),
    flags: localStorage.getItem('homecloud.accessToken') || ""
});