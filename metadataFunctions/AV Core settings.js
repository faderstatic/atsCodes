// created_datetime: 2023-12-20T16:30:19.663970+00:00
// created_with_portal_version: 5.4.1
export default {
    backendSettings: false,
    backendUrl: "/AVAPI",
    endFrameInclusive: true,
    licenseKey:
      "4D304D3260A6914215B3628E23175BEAU8B20749FD3F4A66BD117309F397165F3",
    timeline: {
      waveforms: {
        active: "vidispine",
        vidispine: {
          tag: "original",
          shape: null,
          sampleMin: -43,
          sampleMax: 0
        }
      },
    },
    apps: {
      validate: {
        subtitleTypes: ["timespan"],
      },
      edit: {
        features: {
          autoSave: false,
          saveSequence: true
        },
        metadataKeys: {
          assetType: "av_asset_type",
          sourceAssetId: "av_available_source_asset_id",
          editLockId: "av_edit_edl_lock_id",
        },
      }
    },
    features: {
      assetStatus: true,
      disableAppNavigation: true,
    },
    forms: {
      defaultAsset: {
        schema: {
          type: "object",
          properties: {
            title: {
              type: "string",
            },
            portal_mf201890: {
              type: "integer",
            },
            portal_mf551902: {
              type: "integer",
            },
            portal_mf619153: {
              type: "string",
            },
          },
        },
        uischema: {
          type: "VerticalLayout",
          elements: [
            {
              type: "Control",
              label: "Title",
              scope: "#/properties/title",
            },
            {
              type: "Control",
              label: "Season",
              scope: "#/properties/portal_mf201890",
            },
            {
              type: "Control",
              label: "Episode",
              scope: "#/properties/portal_mf551902",
            },
            {
              type: "Control",
              label: "Description",
              scope: "#/properties/portal_mf619153",
              options: {
                format: "textarea",
              },
            },
          ],
        },
      },
    },
    render: {
      enabledFormats: ["file-per-layer"],
      options: {
        storageSelection: false,
        renderAssetSelection: false,
        renderUrl: '/ap/edit/sequence/render/',
      },
      presets: [
        {
          label: "Lowres (h.264, mp4)",
          metadata: [
            {
              key: "target_tag",
              value: "lowres",
            },
            {
              key: "transcoder",
              value: "Vidispine",
            },
          ],
        },
      ],
    },
    markers: {
      exportFormats: [],
      groups: [
        {
          match: (marker, track) =>
            track?.type === "AvAdBreak" ||
            marker?.metadata?.has("ad_break_type") ||
            marker?.metadata.get("trackId") === "av:adbreak:track:cut",
          title: "Program",
          id: "Adbreak",
          alwaysShow: true,
          allowCreateTrack: false,
          trackType: "AvAdBreak",
          applicationFilters: [
            {
              application: "validate",
              workspace: "Adbreak",
            },
          ],
          rows: [
            {
              match: (marker) =>
                marker?.metadata.get("ad_break_type") === "av:adbreak:marker:break" ||
                marker?.metadata.get("ad_break_type") === "av:adbreak:marker:start" ||
                marker?.metadata.get("ad_break_type") === "av:adbreak:marker:end"
              ,
              track: "av:adbreak:track:break",
              title: "Start, End, Breaks",
              tooltip: (marker) => marker?.metadata.get("description"),
              tooltipFallback: "No description",
              order: 0,
              markerType: "AvAdBreak",
            },
            {
              match: (marker) =>
                marker?.metadata.get("trackId") === "av:adbreak:track:cut",
              form: "cutForm",
              track: "av:adbreak:track:cut",
              title: "Cuts",
              tooltip: (marker) => marker?.metadata.get("description"),
              tooltipFallback: "No description",
              order: 1,
              markerType: "AvAdBreak",
              tag: {
                tag: "Subtracted from duration",
                type: "description",
              },
              markerStyle: {
                backgroundColor: "var(--AP-ERROR)",
              },
            },
          ],
        },
        {
          match: (marker, track) =>
            marker?.type === "AvMarker" || track?.type === "AvMarker",
          title: "Manual",
          id: "Manual",
          alwaysShow: true,
          allowCreateTrack: true,
          trackType: "AvMarker",
          rows: [
            {
              match: (marker) =>
                marker?.metadata.get("trackId") === "av:track:video:issues",
              track: "av:track:video:issues",
              title: "Video issues",
              tooltip: (marker) => marker?.metadata.get("name"),
              order: 0,
              markerType: "AvMarker",
              names: [
                "S&P Comment",
                "Abrupt edit",
                "Aliasing",
                "Animation error",
                "Artifact",
                "Black frames",
                "Freeze frame",
                "Interlacing",
                "Jitter",
                "Letterboxing",
                "Nudity",
                "Posterization",
                "Shifted luminance",
              ],
              markerStyle: {
                backgroundColor: "var(--AP-PRIMARY)",
              },
            },
            {
              match: (marker) =>
                marker?.metadata.get("trackId") === "av:track:audio:issues",
              track: "av:track:audio:issues",
              title: "Audio issues",
              tooltip: (marker) => marker?.metadata.get("name"),
              order: 1,
              markerType: "AvMarker",
              names: [
                "S&P Comment",
                "Audio overlap",
                "Dialogue out of sync",
                "Distortion",
                "Dropout",
                "Glitch",
                "Loudness issue",
                "Missing dialogue",
                "Missing sound effect",
                "Out of pitch",
                "Profanity",
                "Wrong language on track",
              ],
              markerStyle: {
                backgroundColor: "var(--AP-AZURE)",
              },
            },
            {
              match: (marker) =>
                marker?.metadata.get("trackId") === "av:track:subtitle:issues",
              track: "av:track:subtitle:issues",
              title: "Subtitle issues",
              tooltip: (marker) => marker?.metadata.get("name"),
              order: 2,
              markerType: "AvMarker",
              names: [
                "Erratum",
                "Incorrect positioning",
                "Missing censorship",
                "Missing cue",
                "Mistimed cue",
                "Unnecessary censorship",
              ],
              markerStyle: {
                backgroundColor: "var(--AP-SUCCESS)",
              },
            },
            {
              match: (marker) =>
                marker?.metadata.get("trackId") === "av:track:other" ||
                marker?.metadata.get("trackId") === "av:track:warning" ||
                marker?.metadata.get("trackId") === "av:track:issue" ||
                marker?.metadata.get("trackId") === "av:track:serious" ||
                marker?.metadata.get("trackId") === "av:track:info",
              track: "av:track:other",
              title: "Other",
              tooltip: (marker) => marker?.metadata.get("name"),
              order: 3,
              markerType: "AvMarker",
              markerStyle: {
                backgroundColor: "var(--AP-TURQUOISE)",
              },
            },
            {
              match: (marker, track) =>
                !!marker?.metadata.get("trackId") || !!track,
              track: (marker, track) => track.id,
              title: (marker, track) => track?.metadata.get("name"),
              tooltip: (marker) => marker?.metadata.get("name"),
              order: (marker, track) => parseInt(track?.id, 10) + 3 ?? 4,
              markerType: "AvMarker",
              alwaysShow: false,
            },
          ],
        },
        {
          match: () => true, // Default
          id: (marker, track) =>
            marker ? marker.type : track ? track.type : "error",
          title: (marker) => marker.type,
          alwaysHide: true,
          rows: [],
        },
      ],
      markersMetadataSettings: [
        {
          match: (type) => type === "ap:legacy:marker",
          mappings: {
            name: "ap:legacy:marker:name",
            description: "ap:legacy:marker:description",
            trackId: "trackId",
          },
        },
        {
          match: (type) => type === "AvMarker",
          mappings: {
            name: "title",
            description: "av_marker_description",
            trackId: "av_marker_track_id",
          },
        },
        {
          match: (type) => type === "AvAdBreak",
          mappings: {
            name: "title",
            description: "av_marker_description",
            trackId: "av_marker_track_id",
          },
        },
        {
          match: () => true, // Default
          mappings: {
            name: "name",
            description: "description",
            trackId: "subtype",
          },
        },
      ],
      tracksMetadataSettings: [
        {
          match: (type) => type === "AvMarker",
          mappings: {
            name: "title",
            description: "av_marker_description",
          },
        },
        {
          match: () => true, // Default
          mappings: {
            name: "name",
            description: "description",
          },
        },
      ],
    },
    authentication: {
      method: "basic",
      enabled: false,
    },
    eventBus: {
      enabled: false,
    },
    showAssetView: false,
    assetStatus: {
      statusMetadataFieldName: "av_asset_status",
      commentMetadataFieldName: "av_asset_status_comment",
      statusSetByMetadataFieldName: "av_asset_status_set_by",
      statuses: [
        {
          key: "in_progress",
          labels: {
            status: "In progress"
          },
          color: "#9493a0"
        },
        {
          key: "approved",
          labels: {
            status: "Approved",
            assign: "Approve"
          },
          color: "var(--AP-SUCCESS)",
        },
        {
          key: "rejected",
          labels: {
            status: "Rejected",
            assign: "Reject"
          },
          color: "var(--AP-ERROR)",
          revokable: false,
          allowComment: true
        }
      ]
    },
  };
  