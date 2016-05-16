from time import sleep


def check_and_close_biu(b, wait_time):
    """Check for presence of biu alert replacement and close."""
    alert = b.find_elements_by_class_name('biu-close')
    assert len(alert) == 1
    alert[0].click()
    sleep(wait_time)
    alert = b.find_elements_by_class_name('biu-close')
    assert len(alert) == 0
