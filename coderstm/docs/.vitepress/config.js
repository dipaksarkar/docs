import { defineConfig } from 'vitepress'

export default defineConfig({
  lang: 'en-US',
  title: 'Coderstm Documentation',
  description: 'Web design and development company',
  
  lastUpdated: true,
  cleanUrls: 'without-subfolders',

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
