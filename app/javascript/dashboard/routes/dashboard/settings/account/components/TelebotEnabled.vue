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
    const { telebot_enabled } = currentAccount.value?.settings || {};
    isEnabled.value = !!telebot_enabled;
  },
  { deep: true, immediate: true }
);

const toggleTelebot = async () => {
  try {
    await updateAccount({ telebot_enabled: isEnabled.value });
    useAlert(t('GENERAL_SETTINGS.FORM.TELEBOT.API.SUCCESS'));
  } catch (error) {
    useAlert(t('GENERAL_SETTINGS.FORM.TELEBOT.API.ERROR'));
  }
};
</script>

<template>
  <SectionLayout
    :title="t('GENERAL_SETTINGS.FORM.TELEBOT.TITLE')"
    :description="t('GENERAL_SETTINGS.FORM.TELEBOT.NOTE')"
    with-border
  >
    <template #headerActions>
      <div class="flex justify-end">
        <Switch v-model="isEnabled" @change="toggleTelebot" />
      </div>
    </template>
  </SectionLayout>
</template>
