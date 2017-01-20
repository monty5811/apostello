from time import sleep


def check_and_close_msg(b, wait_time):
    """Check for presence of message and close."""
    alert = b.find_elements_by_class_name('close')
    assert len(alert) == 1
    alert[0].click()
    sleep(wait_time)
    alert = b.find_elements_by_class_name('close')
    assert len(alert) == 0
