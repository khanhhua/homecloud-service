import './app.scss';
import { Elm } from './Main.elm';

const API_BASE_URL = process.env.API_BASE_URL || '';

Elm.Main.init({
    node: document.getElementById('elm'),
    flags: {
        accessToken: localStorage.getItem('homecloud.accessToken'),
        apiBaseUrl: API_BASE_URL
    }
});