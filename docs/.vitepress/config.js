import { defineConfig } from 'vitepress'

const NitroFIT28SideBar = [
  {
    text: 'Getting Started',
    items: [
      { text: 'What is NitroFIT28?', link: '/nitrofit28/' },
      { text: 'Installation', link: '/nitrofit28/installation' },
      { text: 'Build Mobile Apps', link: '/nitrofit28/build-apps' },
    ]
  },
  {
    text: 'Usage',
    items: [
      { text: 'Enquiries', link: '/nitrofit28/enquiries' },
      { text: 'Tasks', link: '/nitrofit28/tasks' },
      { text: 'Members', link: '/nitrofit28/members' },
      { 
        text: 'Classes',
        link: '/nitrofit28/classes',
        items: [
          { text: 'Templates', link: '/nitrofit28/classes/templates' },
          { text: 'Locations', link: '/nitrofit28/classes/locations' },
          { text: 'Week Schedules', link: '/nitrofit28/classes/schedules' },
        ] 
      },
      { text: 'Products', link: '/nitrofit28/products' },
      { text: 'Settings', link: '/nitrofit28/settings' },
    ]
  }
]

export default defineConfig({
  lang: 'en-US',
  title: 'NitroFIT28',
  description: 'An easy-to-use GYM and FITNESS Management System.',
  ignoreDeadLinks: true,

  head: [['meta', { name: 'theme-color', content: '#3a80c3' }]],

  markdown: {
    headers: {
      level: [0, 0]
    }
  },

  themeConfig: {
    logo: '/logo.png',
    siteTitle: false,
    nav: [
      { text: 'About Us', link: 'https://coderstm.com/' },
      { text: 'Our Envato', link: 'https://codecanyon.net/user/coderstm' },
    ],

    sidebar: {
      '/nitrofit28/' : NitroFIT28SideBar
    },

    socialLinks: [
      { icon: 'github', link: 'https://github.com/coders-tm' },
      { icon: 'facebook', link: 'https://www.facebook.com/coderstm' },
      { icon: 'linkedin', link: 'https://www.linkedin.com/company/coderstm' },
    ],

    footer: {
      message: 'Crafted with ❤️',
      copyright: 'Copyright © 2022 Coderstm. All Rights Reserved.'
    }
  }
})
