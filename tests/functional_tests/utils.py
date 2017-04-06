from time import sleep


def click_and_wait(elem, t):
    elem.click()
    sleep(t)
    return elem


def check_and_close_msg(b, wait_time):
    """Check for presence of message and close."""
    alert = b.find_elements_by_class_name('close')
    assert len(alert) == 1
    click_and_wait(alert[0], wait_time)
    alert = b.find_elements_by_class_name('close')
    assert len(alert) == 0


def assert_with_timeout(fn, max_t):
    t = 0
    while t <= max_t:
        try:
            fn()
            break
        except AssertionError as e:
            if t < max_t:
                sleep(1)
                t = t + 1
            else:
                raise(e)
