import path from "path";
import "webpack-dev-server";
import { Configuration } from "webpack";

const { ModuleFederationPlugin } = require("webpack").container;
const HtmlWebpackPlugin = require("html-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

const mode = (process.env.NODE_ENV as "development" | "production" | "none") || "development";
const prod = mode === "production";

const config: Configuration = {
  mode,
  entry: "./src/index.tsx",
  devServer: {
    port: 4000,
    open: true,
    hot: true,
    historyApiFallback: true,
    allowedHosts: "all",
  },
  module: {
    rules: [
      {
        test: /\.(js|jsx|tsx)$/,
        exclude: /node_modules/,
        use: "babel-loader",
      },
      {
        test: /.tsx?$/,
        use: "ts-loader",
        exclude: /node_modules/,
      },
      {
        test: /\.css$/,
        use: [
          /**
           * MiniCssExtractPlugin doesn't support HMR.
           * For developing, use 'style-loader' instead.
           * */
          prod ? MiniCssExtractPlugin.loader : "style-loader",
          "css-loader",
          {
            loader: "postcss-loader",
            options: {
              postcssOptions: {
                plugins: {
                  tailwindcss: {},
                  autoprefixer: {},
                },
              },
            },
          },
        ],
      },
    ],
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js", ".json"],
  },
  output: {
    filename: "bundle.js",
    path: path.resolve(__dirname, "dist"),
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: "./src/index.html",
    }),
    new MiniCssExtractPlugin({
      filename: "[name].css",
    }),
    new ModuleFederationPlugin({
      name: "client",
      filename: "remoteEntry.js",
      remotes: {
        host: `${process.env.CONTAINER_NAME}@${process.env.REACT_APP_REMOTE_URL}/remoteEntry.js`,
      },
      exposes: {},
      shared: {},
    }),
  ],
  devtool: prod ? false : "source-map",
};

export default config;
