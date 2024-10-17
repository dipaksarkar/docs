<template>
  <Layout>
    <template #doc-before>
      <div class="vp-banner">
        <div class="tip custom-block">
          <p class="custom-block-title">
            🎉 <strong>Exciting News!</strong> 🎉
          </p>
          <p>
            We are thrilled to announce the launch of <strong>Gympify</strong>,
            our latest SaaS offering derived from NitroFIT28! Gympify is
            designed to streamline gym and fitness management, providing
            enhanced features for both administrators and members.
          </p>
          <p>
            👉 Check it out here:
            <a
              href="https://coderstm.gumroad.com/l/gympify"
              target="_blank"
              rel="noreferrer"
            >
              Gympify
            </a>
          </p>
        </div>
      </div>
    </template>
  </Layout>
</template>
<script>
import DefaultTheme from "vitepress/theme";
import { useRouter } from "vitepress";

const { Layout } = DefaultTheme;

export default {
  components: { Layout },
  setup() {
    let router = useRouter();
    return {
      router,
    };
  },
};
</script>

<style>
.vp-banner {
  margin-bottom: 30px;
}
</style>
