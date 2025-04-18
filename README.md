# UM Tag Publisher Buildkite Plugin

Publish a tag version for Unified Module.

## Example Usage

```yml
steps:
  - label: Publish Tag
    plugins:
        - ssh://git@github.com/thanyalukj/um-tag-publisher-buildkite-plugin.git#v1.0.0:
            platform: 'android'
            tag_name: 'android-contract'
            file_path: 'android/contract/build.gradle'
    agents:
      queue: build
```

## Configuration

### `platform` (Required, string)

Specifies platform. Accepted values are: `android`, `ios`, and `react`

### `tag_name` (Required, string)

Specifies the tag name. Accepted values are: `android-contract`, `android-library`, `ios-contract`, `ios-library`, `react-contract`, and `react-library`.

### `file_path` (Required, string)

Specifies the file_path where the plugin is looking for the version.

## Development

To execute the tests, run the following command:

```shell
docker-compose run --rm tests
```
