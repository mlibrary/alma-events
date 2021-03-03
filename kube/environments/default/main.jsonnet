(import 'alma-webhook/alma-webhook.libsonnet') +
{
  _config+:: {
  },

  _images+:: {
    alma_webhook: {
      web: 'mlibrary/alma-webhook-unstable:830ce82176d418fc78ee33047ac74bfc0622b2e6',
    },
  },
}
