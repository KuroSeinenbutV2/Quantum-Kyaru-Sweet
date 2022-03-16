/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * Copyright (C) 2022 ZyCromerZ
 *
 * Inspired from lyb gpu
 *
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <misc/zyc_gpu.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("ZyCromerZ");
MODULE_DESCRIPTION("zyc gpu");
MODULE_VERSION("0.0.1");

bool __read_mostly use_backport_option = false;
module_param(use_backport_option, bool, 0644);

static int __init prepare_driver_init(void) {
 printk(KERN_INFO "zyc gpu initialized");
 return 0;
}
static void __exit prepare_driver_exit(void) {
 printk(KERN_INFO "zyc gpu exit");
}

module_init(prepare_driver_init);
module_exit(prepare_driver_exit);
