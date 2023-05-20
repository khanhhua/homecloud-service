var webpack = require("webpack");
var path = require("path");
var HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
    entry: {
        main: [
            './src/index.js'
        ]
    },
    output: {
        path: path.resolve(__dirname + '/dist'),
        filename: '[name]-[contenthash].js',
    },
    module: {
        rules: [
            {
                test: /\.(css|scss)$/,
                use: [
                    'style-loader',
                    'css-loader',
                    'sass-loader',
                ],
                generator: {
                    filename: '[name]-[contenthash][ext]'
                }
            },
            {
                test: /\.html$/,
                exclude: /node_modules/,
                loader: 'html-loader',
            },
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: 'elm-webpack-loader',
            },
        ],
        noParse: /\.elm$/,
    },
    plugins: [
        new webpack.EnvironmentPlugin(['API_BASE_URL']),
        new HtmlWebpackPlugin({
            template: 'src/index.html',
        })
    ],
    devServer: {
        hot: true,
        host: '0.0.0.0',
        historyApiFallback: {
            rewrites: [
                { from: /^\/$/, to: '/index.html' },
                { from: /^\/(.+\.js|.+\.css)/, to: '/$1' }
            ],
        },
        proxy: {
            '/api': 'http://localhost:4000',
        }
    },
    mode: "development"
};
