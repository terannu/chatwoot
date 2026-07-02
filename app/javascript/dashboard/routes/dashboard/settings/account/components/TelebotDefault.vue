<script setup>
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAccount } from 'dashboard/composables/useAccount';
import { useAlert } from 'dashboard/composables';
import SectionLayout from './SectionLayout.vue';
import Switch from 'next/switch/Switch.vue';

const { t } = useI18n();
const isEnabled = ref(false);

const { currentAccount, updateAccount } = useAccount();

watch(
  currentAccount,
  () => {
    const { telebot_default_enabled } = currentAccount.value?.settings || {};
    isEnabled.value = !!telebot_default_enabled;
  },
  { deep: true, immediate: true }
);

const toggleTelebotDefault = async () => {
  try {
    await updateAccount({ telebot_default_enabled: isEnabled.value });
    useAlert(t('GENERAL_SETTINGS.FORM.TELEBOT_DEFAULT.API.SUCCESS'));
  } catch (error) {
    useAlert(t('GENERAL_SETTINGS.FORM.TELEBOT_DEFAULT.API.ERROR'));
  }
};
</script>

<template>
  <SectionLayout
    :title="t('GENERAL_SETTINGS.FORM.TELEBOT_DEFAULT.TITLE')"
    :description="t('GENERAL_SETTINGS.FORM.TELEBOT_DEFAULT.NOTE')"
    with-border
  >
    <template #headerActions>
      <div class="flex justify-end">
        <Switch v-model="isEnabled" @change="toggleTelebotDefault" />
      </div>
    </template>
  </SectionLayout>
</template>
