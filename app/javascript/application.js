import "homeland/index";
import "vendor/bootstrap";
import "front/index";

const importAll = (r) => r.keys().map(r)
importAll(require.context('./images', false, /\.(png|jpe?g|svg)$/));
