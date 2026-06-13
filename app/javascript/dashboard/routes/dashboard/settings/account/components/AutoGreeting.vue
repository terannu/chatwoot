<script setup>
import { ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAccount } from 'dashboard/composables/useAccount';
import { useAlert } from 'dashboard/composables';
import SectionLayout from './SectionLayout.vue';
import Switch from 'next/switch/Switch.vue';

const { t } = useI18n();
const isEnabled = ref(false);
const interval = ref(5);

const { currentAccount, updateAccount } = useAccount();

watch(
  currentAccount,
  () => {
    const { auto_greeting_enabled, auto_greeting_interval } =
      currentAccount.value?.settings || {};
    isEnabled.value = !!auto_greeting_enabled;
    interval.value = auto_greeting_interval ?? 5;
  },
  { deep: true, immediate: true }
);

const save = async () => {
  try {
    await updateAccount({
      auto_greeting_enabled: isEnabled.value,
      auto_greeting_interval: Number(interval.value),
    });
    useAlert(t('GENERAL_SETTINGS.FORM.AUTO_GREETING.API.SUCCESS'));
  } catch {
    useAlert(t('GENERAL_SETTINGS.FORM.AUTO_GREETING.API.ERROR'));
  }
};
</script>

<template>
  <SectionLayout
    :title="t('GENERAL_SETTINGS.FORM.AUTO_GREETING.TITLE')"
    :description="t('GENERAL_SETTINGS.FORM.AUTO_GREETING.NOTE')"
    with-border
  >
    <template #headerActions>
      <div class="flex justify-end">
        <Switch v-model="isEnabled" @change="save" />
      </div>
    </template>
    <div v-if="isEnabled" class="flex items-center gap-3 mt-3">
      <label class="text-sm text-n-slate-11 whitespace-nowrap">
        {{ t('GENERAL_SETTINGS.FORM.AUTO_GREETING.INTERVAL_LABEL') }}
      </label>
      <input
        v-model.number="interval"
        type="number"
        min="1"
        class="w-24 px-2 py-1 text-sm border border-n-weak rounded-lg bg-n-alpha-1 text-n-slate-12"
        @change="save"
      />
      <span class="text-sm text-n-slate-11">
        {{ t('GENERAL_SETTINGS.FORM.AUTO_GREETING.INTERVAL_UNIT') }}
      </span>
    </div>
  </SectionLayout>
</template>
