<template>
  <Layout>
    <template #doc-before>
      <div class="vp-banner"></div>
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
