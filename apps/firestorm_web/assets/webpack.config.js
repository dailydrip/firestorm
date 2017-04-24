const webpack = require('webpack')
const path = require('path')

const nodeEnv = process.env.NODE_ENV || 'development'
const isProd = nodeEnv === 'production'

// Change node process to the firestorm_web root
process.chdir(__dirname)

const staticDir = path.join(__dirname, '.')
const destDir = path.join(__dirname, '../priv/static')
const publicPath = '/'

const ExtractTextPlugin = require('extract-text-webpack-plugin')
const CopyWebpackPlugin = require("copy-webpack-plugin")

module.exports = {
  entry: [staticDir + '/js/app.js', staticDir + '/css/app.scss'],
  output: {
    path: destDir,
    filename: 'js/app.js',
    publicPath,
  },
  resolve: {
    alias: {
      config: path.resolve(__dirname, `./config/${nodeEnv}.js`)
    }
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: [/node_modules/],
        use: [
          {
            loader: 'babel-loader',
          }
        ],
      },
      {
        test: /\.s?css$/,
        use: ExtractTextPlugin.extract({
          use: "css-loader!sass-loader!import-glob-loader",
          fallback: "style-loader",
        }),
      },
      {
        test: /\.(png)$/,
        loader: 'file-loader?name=images/[name].[ext]'
      },
      {
        test: /\.(eot|svg|ttf|woff|woff2)$/,
        loader: 'file-loader?name=fonts/[name].[ext]'
      },
      {
        test: /\.woff(2)?(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "url-loader?limit=10000&mimetype=application/font-woff"
      },
      {
        test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
        loader: "file-loader"
      }
    ],
  },
  devServer: {
    contentBase: staticDir,
  },
  plugins: [
    new ExtractTextPlugin('css/app.css'),
    new CopyWebpackPlugin([{ from: './static/images', to: 'images' }]),
  ],
}
