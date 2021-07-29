import fs from 'fs/promises';
import path from 'path';

export default (options) => ({
    name: 'bookshop-component',
    setup: (build) => {
        build.onResolve({ filter: /^__bookshop_file__/ }, async (args) => {
            const primaryBookshopDir = options?.bookshopDirs?.[0];
            if (!primaryBookshopDir) return;
            return {
                path: args.path.replace(/^__bookshop_file__/, ''),
                namespace: 'bookshop-import-component',
                pluginData: {
                    resolveDir: path.join(primaryBookshopDir)
                },
            };
        });
        build.onLoad({ filter: /.*/, namespace: 'bookshop-import-component' }, async (args) => {
            const filePath = path.join(args.pluginData.resolveDir, args.path);
            const fileContents = await fs.readFile(filePath, 'utf8');
            return { contents: fileContents, loader: 'text', resolveDir: args.pluginData.resolveDir };
        });
    },
});
