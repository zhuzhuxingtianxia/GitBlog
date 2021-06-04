const { 
    override, 
    fixBabelImports, 
    addLessLoader,
    addDecoratorsLegacy,
    addWebpackResolve
} = require('customize-cra');

const path = require('path')

module.exports = override(
    fixBabelImports('import', {
        libraryName: 'antd-mobile',
        style: true,
    }),
    addLessLoader({
        javascriptEnabled: true
    }),
    addDecoratorsLegacy(),
    addWebpackResolve({
        extensions: ['.js', '.jsx', '.json'],
        alias: {
            '@config': path.resolve(__dirname,'src/config'),
            '@com': path.resolve(__dirname,'src/containers/components'),
            '@pages': path.resolve(__dirname,'src/containers/pages')
        }
    })
);