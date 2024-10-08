import { defineConfig } from "vitepress";

const NitroFIT28SideBar = [
  {
    text: "Getting Started",
    items: [
      { text: "What is NitroFIT28?", link: "/nitrofit28/" },
      { text: "Installation", link: "/nitrofit28/installation" },
      { text: "Upgrade Guide", link: "/nitrofit28/upgrade" },
      { text: "Changelog", link: "/nitrofit28/changelog" },
    ],
  },
  {
    text: "Usage",
    items: [
      { text: "Enquiries", link: "/nitrofit28/enquiries" },
      { text: "Tasks", link: "/nitrofit28/tasks" },
      { text: "Members", link: "/nitrofit28/members" },
      { text: "Reports", link: "/nitrofit28/reports" },
      { text: "Instructors", link: "/nitrofit28/instructors" },
      { text: "Week Schedules", link: "/nitrofit28/week-schedules" },
      { text: "Orders", link: "/nitrofit28/orders" },
      { text: "Announcements", link: "/nitrofit28/announcements" },
    ],
  },
  {
    text: "Classes",
    items: [
      { text: "Set up Classes", link: "/nitrofit28/classes" },
      { text: "Templates", link: "/nitrofit28/classes/templates" },
      { text: "Locations", link: "/nitrofit28/classes/locations" },
      { text: "Week Schedules", link: "/nitrofit28/classes/schedules" },
    ],
  },
  {
    text: "Products",
    items: [
      { text: "Manage products", link: "/nitrofit28/products" },
      {
        text: "Adding & updating products",
        link: "/nitrofit28/products/add-update",
      },
      { text: "Managing inventory", link: "/nitrofit28/products/inventory" },
      { text: "Product details", link: "/nitrofit28/products/details" },
      { text: "Variants", link: "/nitrofit28/products/variants" },
      { text: "Collections", link: "/nitrofit28/products/collections" },
    ],
  },
  {
    text: "Users and Permissions",
    items: [
      { text: "Staff", link: "/nitrofit28/staff" },
      { text: "Groups", link: "/nitrofit28/staff/groups" },
    ],
  },
  {
    text: "App Settings",
    items: [
      { text: "Settings", link: "/nitrofit28/settings" },
      { text: "Locations", link: "/nitrofit28/settings/locations" },
      { text: "Payments", link: "/nitrofit28/settings/payments" },
      { text: "Notification", link: "/nitrofit28/settings/notifications" },
      { text: "Taxes", link: "/nitrofit28/settings/taxes" },
      { text: "Plans", link: "/nitrofit28/settings/plans" },
      { text: "Coupons", link: "/nitrofit28/settings/coupons" },
    ],
  },
  {
    text: "Developer Docs",
    items: [
      { text: "Getting Started", link: "/nitrofit28/development/setup" },
      { text: "Build Mobile Apps", link: "/nitrofit28/development/build-apps" },
      { text: "Theme Development", link: "/nitrofit28/development/themes" },
      { text: "Scripts", link: "/nitrofit28/development/scripts" },
    ],
  },
];

const QaravelSideBar = [
  {
    text: "Getting Started",
    items: [
      { text: "What is Qaravel?", link: "/qaravel/" },
      { text: "Development", link: "/qaravel/development" },
      { text: "Upgrade Guide", link: "/qaravel/upgrade" },
      { text: "Installation", link: "/qaravel/installation" },
      { text: "Build Mobile Apps", link: "/qaravel/build-apps" },
    ],
  },
  {
    text: "Usage",
    items: [
      { text: "Enquiries", link: "/qaravel/enquiries" },
      { text: "Tasks", link: "/qaravel/tasks" },
      { text: "Members", link: "/qaravel/members" },
    ],
  },
  {
    text: "Users and Permissions",
    items: [
      { text: "Staff", link: "/qaravel/staff" },
      { text: "Groups", link: "/qaravel/staff/groups" },
    ],
  },
  {
    text: "App Settings",
    items: [
      { text: "Settings", link: "/qaravel/settings" },
      { text: "Payments", link: "/qaravel/settings/payments" },
      { text: "Notification", link: "/qaravel/settings/notifications" },
      { text: "Taxes", link: "/qaravel/settings/taxes" },
      { text: "Plans", link: "/qaravel/settings/plans" },
      { text: "Coupons", link: "/qaravel/settings/coupons" },
    ],
  },
];

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
      "/nitrofit28/": NitroFIT28SideBar,
      "/qaravel/": QaravelSideBar,
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
