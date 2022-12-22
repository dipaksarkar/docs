import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'en-US',
  title: 'NitroFIT28',
  description: 'An easy-to-use GYM and FITNESS Management System.',
  base: '/nitrofit28/',
  
  lastUpdated: true,
  cleanUrls: 'without-subfolders',

  head: [['meta', { name: 'theme-color', content: '#3a80c3' }]],

  markdown: {
    headers: {
      level: [0, 0]
    }
  },

  themeConfig: {
    logo: '/logo.svg',
    siteTitle: false,
    nav: [
      { text: 'About Us', link: 'https://coderstm.com/' },
      { text: 'Our Envato', link: 'https://codecanyon.net/user/coderstm' },
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'What is NitroFIT28?', link: '/overview' },
          { text: 'Installation', link: '/installation' },
          { text: 'License', link: '/license' }
        ]
      },
      {
        text: 'Usage',
        items: [
          { text: 'Opening Times', link: '/opening-times' },
          { text: 'Membership', link: '/membership' },
        ]
      }
    ],

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
