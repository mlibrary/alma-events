{
  _config+:: {
    alma_webhook: {
      web: {
        name: 'web',
        port: 4567,
        host: 'testing.alma-webhook.kubernetes.lib.umich.edu',
      },
    },
  },

  _images+:: {
    alma_webhook: {
      web: 'mlibrary/alma-webhook-unstable',
    },
  },
}
