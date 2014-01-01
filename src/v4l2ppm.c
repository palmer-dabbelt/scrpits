#ifdef HAVE_LIBV4L2

/* part of media-libs/libv4l */
#include <libv4l2.h>

#include <linux/videodev2.h>
#include <sys/mman.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <stdlib.h>
#include <stdint.h>

#define V4L_FORMAT   V4L2_PIX_FMT_RGB24
#define IMAGE_WIDTH    800
#define IMAGE_HEIGHT   600
#define VIDEO_PATH   "/dev/video0"
#define IMAGE_PATH   "v4l2.ppm"

int main(int argc, char **argv)
{
    int err;
    int video_dev;
    static struct v4l2_format format;
    uint8_t *image_data;
    int image_width, image_height;
    char *output_filename;

    /* Opens the video VIDEO_PATH using the wrapped call */
    if (argc == 3)
        video_dev = v4l2_open(argv[2], O_RDWR);
    else
        video_dev = v4l2_open(VIDEO_PATH, O_RDWR);

    if (video_dev == 0) {
        fprintf(stderr, "Unable to open video dev\n");
        abort();
    }

    /* Zeros out the format, just in case */
    memset(&format, 0x00, sizeof(format));

    /* Fills in the format type to get BGR24 */
    format.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    format.fmt.pix.pixelformat = V4L_FORMAT;
    format.fmt.pix.width = IMAGE_WIDTH;
    format.fmt.pix.height = IMAGE_HEIGHT;

    /* Calls the IOCTL to set the format */
    err = v4l2_ioctl(video_dev, VIDIOC_S_FMT, &format);
    assert(err == 0);

    /* The call _will_ succeed because we are using the wrapper, but to make
     * sure we can test anyway */
    assert(format.fmt.pix.pixelformat == V4L_FORMAT);

    /* Creates some space to store the data */
    image_width = format.fmt.pix.width;
    image_height = format.fmt.pix.height;
    image_data = malloc(3 * image_width * image_height);
    assert(image_data != NULL);

    /* Figures out where to save the photo */
    if (argc == 1)
        output_filename = IMAGE_PATH;
    else if ((argc == 2) || (argc == 3))
        output_filename = argv[1];
    else {
        fprintf(stderr, "Wrong number of arguments\n");
        abort();
    }

    /* Actually takes the picture */
    {
        int size;
        FILE *file;
        int written;

        size = 3 * image_width * image_height;
        v4l2_read(video_dev, image_data, size);

        file = fopen(output_filename, "w");
        fprintf(file, "P6\n%d %d\n%d\n", image_width, image_height, 255);
        written = fwrite(image_data, size, 1, file);
        fclose(file);
    }
}

#else /* HAVE_V4L2 */

#include <stdio.h>

int main(int argc __attribute__ ((unused)), int argv __attribute__ ((unused)))
{
    fprintf(stderr, "libv4l2 not installed\n");

    return 1;
}

#endif
