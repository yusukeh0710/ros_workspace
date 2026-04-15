#!/usr/bin/env python3
"""ROS converter entrypoint (scaffold)."""

import argparse
from io import BytesIO
from pathlib import Path
import numpy as np
from PIL import Image

from rosbags.highlevel import AnyReader
from rosbags.rosbag2 import Writer, StoragePlugin
from rosbags.typesys import Stores, get_typestore

import matplotlib.pyplot as plt


def arg_parse() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="convert.py",
        description="Scaffold for converting ROS bag data to MCAP without ROS build tools.",
    )
    parser.add_argument("--input", type=Path, help="Input bag file or directory path.")
    parser.add_argument("--output", type=Path, help="Output MCAP file path.")
    return parser



def _is_camera_topic(topic: str, msgtype: str) -> bool:
    return "image" in topic and msgtype is not None


def _show_image(image: np.ndarray) -> None:
    plt.imshow(image, cmap="gray")
    plt.axis("off")
    plt.show(block=False)
    plt.pause(0.001)


def _decode_image(msg) -> np.ndarray:
    return np.frombuffer(msg.data, dtype=np.uint8).reshape(msg.height, msg.width)


def _to_jpeg_bytes(image: np.ndarray) -> np.ndarray:
    buf = BytesIO()
    Image.fromarray(image).save(buf, format="JPEG")
    return np.frombuffer(buf.getvalue(), dtype=np.uint8).copy()


def convert(input_path: Path, output_path: Path) -> None:
    NEW_CAMERA_MESSAGE = "sensor_msgs/msg/CompressedImage"
    new_typestore = get_typestore(Stores.ROS2_JAZZY)

    with AnyReader([input_path]) as reader, Writer(
        output_path, version=8, storage_plugin=StoragePlugin.MCAP
    ) as writer:
        out_connections = {}
        for connection in reader.connections:
            if _is_camera_topic(connection.topic, connection.msgtype):
                msgtype = NEW_CAMERA_MESSAGE
            else:
                msgtype = connection.msgtype

            typestore = new_typestore if new_typestore.types.keys() else reader.typestore
            out_connections[connection.id] = writer.add_connection(
                connection.topic,
                msgtype,
                serialization_format="cdr",
                typestore=typestore,
            )

        for connection, timestamp, rawdata in reader.messages():
            topic = connection.topic
            msgtype = connection.msgtype

            msg = reader.deserialize(rawdata, msgtype)
            if _is_camera_topic(topic, msgtype):
                image = _decode_image(msg)
#                _show_image(image)

                compressed_class = new_typestore.types[NEW_CAMERA_MESSAGE]
                outmsg = compressed_class(
                    header=msg.header,
                    format="jpeg",
                    data=_to_jpeg_bytes(image),
                )
                payload = new_typestore.serialize_cdr(outmsg, NEW_CAMERA_MESSAGE)
            else:
                typestore = new_typestore if new_typestore.types.keys() else reader.typestore
                payload = typestore.serialize_cdr(msg, msgtype)

            writer.write(out_connections[connection.id], timestamp, payload)

    plt.show()


def main() -> int:
    parser = arg_parse()
    args = parser.parse_args()

    if args.input is None or args.output is None:
        parser.print_help()
        return 0

    convert(args.input, args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
