import { defineConfig } from "vitepress";
import nitrofit28 from "./sidebar/nitrofit28";
import qaravel from "./sidebar/qaravel";
import gympify from "./sidebar/gympify";
import bouncifypro from "./sidebar/bouncifypro";

export default defineConfig({
  lang: "en-US",
  title: "Documentation",
  description: "Official documentation for our products",
  ignoreDeadLinks: true,

  head: [["meta", { name: "theme-color", content: "#3a80c3" }]],

  markdown: {
    headers: {
      level: [0, 0],
    },
  },

  themeConfig: {
    logo: { light: "/logo-dark.png", dark: "/logo-light.png" }, //"/logo.png"
    siteTitle: false,
    nav: [
      { text: "About Us", link: "https://coderstm.com/" },
      { text: "Our Envato", link: "https://codecanyon.net/user/coderstm" },
    ],

    sidebar: {
      "/nitrofit28/": nitrofit28,
      "/gympify/": gympify,
      "/qaravel/": qaravel,
      "/bouncifypro/": bouncifypro,
    },

    socialLinks: [
      { icon: "github", link: "https://github.com/coders-tm" },
      { icon: "facebook", link: "https://www.facebook.com/coderstm" },
      { icon: "linkedin", link: "https://www.linkedin.com/company/coderstm" },
    ],

    footer: {
      message: "Crafted with ❤️",
      copyright: "Copyright © 2022 Coderstm. All Rights Reserved.",
    },
  },
});
